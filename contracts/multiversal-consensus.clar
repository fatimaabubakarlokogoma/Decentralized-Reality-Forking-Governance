;; Multiversal Consensus Mechanism Contract

(define-map votes
  { proposal-id: uint, voter: principal }
  { vote: bool }
)

(define-map vote-counts
  { proposal-id: uint }
  { yes-votes: uint, no-votes: uint }
)

(define-public (cast-vote (proposal-id uint) (vote bool))
  (let
    ((current-counts (default-to { yes-votes: u0, no-votes: u0 } (map-get? vote-counts { proposal-id: proposal-id })))
     (previous-vote (map-get? votes { proposal-id: proposal-id, voter: tx-sender })))

    ;; Update vote counts
    (if (is-some previous-vote)
      ;; If changing vote, adjust counts accordingly
      (if (is-eq (unwrap-panic previous-vote) { vote: vote })
        ;; Vote unchanged, do nothing to counts
        (map-set votes { proposal-id: proposal-id, voter: tx-sender } { vote: vote })
        ;; Vote changed, update counts
        (begin
          (map-set votes { proposal-id: proposal-id, voter: tx-sender } { vote: vote })
          (map-set vote-counts
            { proposal-id: proposal-id }
            (if vote
              ;; Changed to yes
              { yes-votes: (+ (get yes-votes current-counts) u1), no-votes: (- (get no-votes current-counts) u1) }
              ;; Changed to no
              { yes-votes: (- (get yes-votes current-counts) u1), no-votes: (+ (get no-votes current-counts) u1) }
            )
          )
        )
      )
      ;; First time voting
      (begin
        (map-set votes { proposal-id: proposal-id, voter: tx-sender } { vote: vote })
        (map-set vote-counts
          { proposal-id: proposal-id }
          (if vote
            ;; Voting yes
            { yes-votes: (+ (get yes-votes current-counts) u1), no-votes: (get no-votes current-counts) }
            ;; Voting no
            { yes-votes: (get yes-votes current-counts), no-votes: (+ (get no-votes current-counts) u1) }
          )
        )
      )
    )
    (ok true)
  )
)

(define-read-only (get-vote (proposal-id uint) (voter principal))
  (map-get? votes { proposal-id: proposal-id, voter: voter })
)

(define-read-only (get-vote-counts (proposal-id uint))
  (default-to { yes-votes: u0, no-votes: u0 } (map-get? vote-counts { proposal-id: proposal-id }))
)

(define-read-only (has-consensus (proposal-id uint) (threshold uint))
  (let
    ((counts (get-vote-counts proposal-id)))
    (>= (get yes-votes counts) threshold)
  )
)

