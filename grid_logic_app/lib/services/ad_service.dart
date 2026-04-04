// Ad Service - AdMob integration for Grid Logic

import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

// USING GOOGLE TEST AD IDs - These show test ads and are safe for development
// BEFORE PRODUCTION: Replace with real AdMob IDs from https://apps.admob.com/
// iOS: Create app for bundle ID com.heldig.gridlogic
// Android: Create app for package com.heldig.gridlogic

class AdService {
  static final AdService instance = AdService._();
  AdService._();

  bool _isInitialized = false;
  bool _adsRemoved = false;

  // Google's Official Test Ad Unit IDs
  static String get _bannerAdUnitId => Platform.isIOS
      ? 'ca-app-pub-3940256099942544/2934735716' // iOS Test Banner
      : 'ca-app-pub-3940256099942544/6300978111'; // Android Test Banner

  static String get _interstitialAdUnitId => Platform.isIOS
      ? 'ca-app-pub-3940256099942544/4411468910' // iOS Test Interstitial
      : 'ca-app-pub-3940256099942544/1033173712'; // Android Test Interstitial

  static String get _rewardedAdUnitId => Platform.isIOS
      ? 'ca-app-pub-3940256099942544/1712485313' // iOS Test Rewarded
      : 'ca-app-pub-3940256099942544/5224354917'; // Android Test Rewarded

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  int _interstitialLoadAttempts = 0;
  int _rewardedLoadAttempts = 0;
  static const int _maxLoadAttempts = 3;

  // Frequency control
  DateTime? _lastInterstitialShown;
  static const Duration _interstitialCooldown = Duration(minutes: 3);
  int _levelsCompletedSinceLastAd = 0;
  static const int _levelsPerInterstitial = 3;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request consent BEFORE initializing ads
      await _requestConsent();

      // Initialize AdMob AFTER consent
      await MobileAds.instance.initialize();
      _isInitialized = true;

      // Preload ads
      _loadInterstitialAd();
      _loadRewardedAd();
    } catch (e) {
      debugPrint('Ad initialization error: $e');
    }
  }

  /// Request ATT and UMP consent before showing ads
  Future<void> _requestConsent() async {
    try {
      // 1. iOS ATT (App Tracking Transparency) - CRITICAL for App Store approval
      if (Platform.isIOS) {
        final status = await AppTrackingTransparency.trackingAuthorizationStatus;

        if (status == TrackingStatus.notDetermined) {
          await Future.delayed(const Duration(seconds: 1));
          await AppTrackingTransparency.requestTrackingAuthorization();
        }

        debugPrint('ATT Status: $status');
      }

      // 2. UMP (User Messaging Platform) for GDPR
      // Note: UMP consent is handled automatically by google_mobile_ads
      // when initializing with MobileAds.instance.initialize()
      // The SDK will show consent forms automatically for EU users
    } catch (e) {
      debugPrint('Consent request error: $e');
    }
  }

  void setAdsRemoved(bool removed) {
    _adsRemoved = removed;
  }

  // Banner Ad Widget
  BannerAd? createBannerAd() {
    if (_adsRemoved) return null;

    return BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => debugPrint('Banner ad loaded'),
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  // Interstitial Ad
  void _loadInterstitialAd() {
    if (_adsRemoved) return;

    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialLoadAttempts = 0;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadInterstitialAd(); // Preload next
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _interstitialLoadAttempts++;
          if (_interstitialLoadAttempts < _maxLoadAttempts) {
            Future.delayed(
              Duration(seconds: _interstitialLoadAttempts * 2),
              _loadInterstitialAd,
            );
          }
        },
      ),
    );
  }

  Future<void> showInterstitialAd() async {
    if (_adsRemoved) return;

    // Frequency check
    if (_lastInterstitialShown != null &&
        DateTime.now().difference(_lastInterstitialShown!) < _interstitialCooldown) {
      return;
    }

    _levelsCompletedSinceLastAd++;
    if (_levelsCompletedSinceLastAd < _levelsPerInterstitial) {
      return; // Show every 3 levels
    }

    if (_interstitialAd != null) {
      await _interstitialAd!.show();
      _lastInterstitialShown = DateTime.now();
      _levelsCompletedSinceLastAd = 0;
      _interstitialAd = null;
    } else {
      _loadInterstitialAd(); // Try to load if not available
    }
  }

  // Rewarded Ad (for hints)
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedLoadAttempts = 0;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadRewardedAd(); // Preload next
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _rewardedLoadAttempts++;
          if (_rewardedLoadAttempts < _maxLoadAttempts) {
            Future.delayed(
              Duration(seconds: _rewardedLoadAttempts * 2),
              _loadRewardedAd,
            );
          }
        },
      ),
    );
  }

  Future<bool> showRewardedAd() async {
    if (_rewardedAd == null) {
      _loadRewardedAd();
      return false;
    }

    bool rewardEarned = false;

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        rewardEarned = true;
      },
    );

    _rewardedAd = null;
    return rewardEarned;
  }

  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
