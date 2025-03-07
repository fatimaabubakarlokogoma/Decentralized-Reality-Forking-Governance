;; Reality Branch Proposal Contract

(define-map proposals
  { id: uint }
  {
    proposer: principal,
    description: (string-utf8 256),
    fork-point: uint,
    status: (string-ascii 20)
  }
)

(define-data-var next-proposal-id uint u0)

(define-public (create-proposal (description (string-utf8 256)) (fork-point uint))
  (let
    ((new-id (var-get next-proposal-id)))
    (var-set next-proposal-id (+ new-id u1))
    (ok (map-set proposals
      { id: new-id }
      {
        proposer: tx-sender,
        description: description,
        fork-point: fork-point,
        status: "pending"
      }
    ))
  )
)

(define-public (update-proposal-status (proposal-id uint) (new-status (string-ascii 20)))
  (match (map-get? proposals { id: proposal-id })
    proposal (ok (map-set proposals
      { id: proposal-id }
      (merge proposal { status: new-status })
    ))
    (err u404)
  )
)

(define-read-only (get-proposal (proposal-id uint))
  (map-get? proposals { id: proposal-id })
)

