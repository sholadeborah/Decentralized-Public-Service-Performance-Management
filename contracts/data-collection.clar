;; data-collection.clar
;; Records service delivery statistics

;; Map to store performance data entries
(define-map performance-data (tuple (metric-id uint) (period uint))
  {
    value: uint,
    submission-date: uint,
    submitter: principal,
    notes: (string-utf8 500)
  }
)

;; Submit performance data
(define-public (submit-data
                (metric-id uint)
                (period uint)
                (value uint)
                (notes (string-utf8 500))
                (agency-principal principal))
  (let ((data-entry {
          value: value,
          submission-date: block-height,
          submitter: tx-sender,
          notes: notes
        }))
    ;; For simplicity, we'll assume the caller is authorized
    ;; In production, you would verify against the metric and service
    (if (is-eq tx-sender agency-principal)
        (ok (map-set performance-data (tuple (metric-id metric-id) (period period)) data-entry))
        (err u403))))

;; Update performance data
(define-public (update-data
                (metric-id uint)
                (period uint)
                (value uint)
                (notes (string-utf8 500))
                (agency-principal principal))
  (let ((existing-data (unwrap! (map-get? performance-data (tuple (metric-id metric-id) (period period))) (err u404))))
    (if (and (is-eq tx-sender agency-principal)
             (is-eq tx-sender (get submitter existing-data)))
        (ok (map-set performance-data
                     (tuple (metric-id metric-id) (period period))
                     (merge existing-data {
                       value: value,
                       notes: notes,
                       submission-date: block-height
                     })))
        (err u403))))

;; Get performance data
(define-read-only (get-performance-data (metric-id uint) (period uint))
  (map-get? performance-data (tuple (metric-id metric-id) (period period))))
