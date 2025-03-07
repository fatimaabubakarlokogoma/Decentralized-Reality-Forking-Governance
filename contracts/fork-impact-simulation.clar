;; Fork Impact Simulation Contract

(define-map simulations
  { id: uint }
  {
    proposal-id: uint,
    stability-score: uint,
    resource-impact: int,
    simulation-data: (string-utf8 256)
  }
)

(define-data-var next-simulation-id uint u0)

(define-public (create-simulation (proposal-id uint) (stability-score uint) (resource-impact int) (simulation-data (string-utf8 256)))
  (let
    ((new-id (var-get next-simulation-id)))
    (var-set next-simulation-id (+ new-id u1))
    (ok (map-set simulations
      { id: new-id }
      {
        proposal-id: proposal-id,
        stability-score: stability-score,
        resource-impact: resource-impact,
        simulation-data: simulation-data
      }
    ))
  )
)

(define-read-only (get-simulation (simulation-id uint))
  (map-get? simulations { id: simulation-id })
)

(define-read-only (get-simulations-for-proposal (proposal-id uint))
  ;; In a real implementation, this would filter and return all simulations for a proposal
  ;; For simplicity, we'll just return a placeholder
  (ok proposal-id)
)

(define-read-only (is-fork-safe (simulation-id uint))
  (match (map-get? simulations { id: simulation-id })
    simulation (>= (get stability-score simulation) u70)
    false
  )
)

