;; A simple Savings Pool smart contract in Clarity.
;; This contract allows users to deposit STX tokens into a shared
;; pool and withdraw their own contributions at any time.
;; No code needed here. This is just a comment section.
;; --- Data Definitions ---

;; Define the contract owner, which is the deployer's address.
;; This will be set to 'ST3B6M4E7M9BR9GZQTN4TEQYYKJ60E932Z4YZQQC9' upon deployment.
(define-data-var contract-owner principal 'ST3B6M4E7M9BR9GZQTN4TEQYYKJ60E932Z4YZQQC9)

;; Define the state variable for the total balance of the pool.
(define-data-var pool-balance uint u0)

;; Define a map to store the individual contribution of each user.
;; The key is the user's principal (address), and the value is their contribution amount.
(define-map user-contributions principal uint)

;; --- Constants and Errors ---

;; The STX token contract address is SP0000000000000000000020522CDD250C3322E8D3.stx-token
;; (No need to define a constant for it in this contract)

;; Define error codes for different failure scenarios.
(define-constant ERR-UNAUTHORIZED u100) ;; For unauthorized calls
(define-constant ERR-INVALID-AMOUNT u101) ;; For invalid deposit/withdrawal amounts
(define-constant ERR-INSUFFICIENT-FUNDS u102) ;; When a user tries to withdraw more than their contribution
(define-constant ERR-TRANSFER-FAILED u103) ;; When a token transfer fails

;; Define the minimum deposit amount and withdrawal fee.
(define-constant MIN-DEPOSIT u10000) ;; 0.01 STX (with 6 decimals)
(define-constant WITHDRAWAL-FEE u500) ;; 0.0005 STX (with 6 decimals)

;; --- Public Functions (Writable) ---

;; Function to deposit STX into the savings pool.
;; It takes a single argument, 'amount', of type unsigned integer.
(define-public (deposit (amount uint))
  (begin
    ;; Assert that the deposit amount meets the minimum requirement.
    (asserts! (>= amount MIN-DEPOSIT) (err ERR-INVALID-AMOUNT))

    ;; Transfer the specified amount of STX from the sender to this contract.
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))

    ;; Update the user's contribution and the pool balance.
    (let
      ( (current-contribution (default-to u0 (map-get? user-contributions tx-sender))) )
      (map-set user-contributions tx-sender (+ current-contribution amount))
    )
    (var-set pool-balance (+ (var-get pool-balance) amount))
    
    ;; Return an 'ok' response with the new contribution amount.
    (ok (default-to u0 (map-get? user-contributions tx-sender)))
  )
)

;; Function to withdraw STX from the savings pool.
;; It takes a single argument, 'amount', of type unsigned integer.
(define-public (withdraw (amount uint))
  (begin
    ;; Assert that the withdrawal amount is valid (greater than 0 and includes fee).
    (asserts! (> amount WITHDRAWAL-FEE) (err ERR-INVALID-AMOUNT))
    
    ;; Get the sender's current contribution.
    (let
      (
        (current-contribution (default-to u0 (map-get? user-contributions tx-sender)))
        (total-withdrawal-amount (+ amount WITHDRAWAL-FEE))
      )
      ;; Assert that the user has enough funds to cover the withdrawal and the fee.
      (asserts! (>= current-contribution total-withdrawal-amount) (err ERR-INSUFFICIENT-FUNDS))

      ;; Transfer the specified amount of STX from this contract to the sender.
      (try! (stx-transfer? amount (as-contract tx-sender) tx-sender))

      ;; Update the user's contribution and the pool balance.
      (let
        (
          (new-contribution (- current-contribution total-withdrawal-amount))
          (new-pool-balance (- (var-get pool-balance) total-withdrawal-amount))
        )
        (map-set user-contributions tx-sender new-contribution)
        (var-set pool-balance new-pool-balance)
        
        ;; Return an 'ok' response with the new contribution amount.
        (ok new-contribution)
      )
    )
  )
)

;; --- Read-only Functions (View-only) ---

;; Read-only function to get the total balance of the savings pool.
(define-read-only (get-pool-balance)
  (ok (var-get pool-balance))
)

;; Read-only function to get a specific user's contribution.
(define-read-only (get-user-contribution (user principal))
  (ok (default-to u0 (map-get? user-contributions user)))
)