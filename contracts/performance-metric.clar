;; performance-metric.clar
;; Establishes measurement standards

(define-data-var admin principal tx-sender)

;; Map to store metrics by ID
(define-map metrics uint
  {
    name: (string-utf8 100),
    description: (string-utf8 500),
    service-id: uint,
    unit: (string-utf8 50),
    target-value: uint,
    creation-date: uint,
    agency-principal: principal
  }
)

;; Counter for metric IDs
(define-data-var next-metric-id uint u1)

;; Define a new metric
(define-public (define-metric
                (name (string-utf8 100))
                (description (string-utf8 500))
                (service-id uint)
                (unit (string-utf8 50))
                (target-value uint)
                (agency-principal principal))
  (let ((metric-id (var-get next-metric-id))
        (metric-data {
          name: name,
          description: description,
          service-id: service-id,
          unit: unit,
          target-value: target-value,
          creation-date: block-height,
          agency-principal: agency-principal
        }))
    ;; For simplicity, we'll assume the caller is authorized
    ;; In production, you would verify against the service registration
    (var-set next-metric-id (+ metric-id u1))
    (ok (map-set metrics metric-id metric-data))))

;; Update a metric
(define-public (update-metric
                (metric-id uint)
                (name (string-utf8 100))
                (description (string-utf8 500))
                (unit (string-utf8 50))
                (target-value uint))
  (let ((metric-data (unwrap! (map-get? metrics metric-id) (err u404))))
    (if (is-eq tx-sender (get agency-principal metric-data))
        (ok (map-set metrics
                     metric-id
                     (merge metric-data {
                       name: name,
                       description: description,
                       unit: unit,
                       target-value: target-value
                     })))
        (err u403))))

;; Get metric details
(define-read-only (get-metric-details (metric-id uint))
  (map-get? metrics metric-id))

;; Get current metric count
(define-read-only (get-metric-count)
  (- (var-get next-metric-id) u1))
