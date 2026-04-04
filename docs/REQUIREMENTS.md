# Grid Logic Requirements

## 1. Functional Requirements
- **FR-01 (Gameplay):** The core mechanic (Constraint satisfaction algorithm generating valid clues for a given truth matrix.) must execute flawlessly at 60fps.
- **FR-02 (Progression):** The system must save the user's level progress locally.
- **FR-03 (Ads):** The system must request ATT tracking consent (iOS) and UMP consent (EU) before initializing AdMob.
- **FR-04 (Rewarded):** The system must correctly grant the reward callback after a video completes.

## 2. Non-Functional Requirements
- **NFR-01 (Bundle Size):** The app must stay under 25MB to ensure high conversion on cellular networks.
- **NFR-02 (Offline):** The game must be fully playable in Airplane mode (though ads will not load).
