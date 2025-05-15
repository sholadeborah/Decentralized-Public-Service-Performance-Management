;; service-registration.clar
;; Records public service offerings

(define-data-var admin principal tx-sender)

;; Map to store services by ID
(define-map services uint
  {
    name: (string-utf8 100),
    description: (string-utf8 500),
    agency-principal: principal,
    active: bool,
    creation-date: uint
  }
)

;; Counter for service IDs
(define-data-var next-service-id uint u1)

;; Register a new service
(define-public (register-service
                (name (string-utf8 100))
                (description (string-utf8 500))
                (agency-principal principal))
  (let ((service-id (var-get next-service-id))
        (service-data {
          name: name,
          description: description,
          agency-principal: agency-principal,
          active: true,
          creation-date: block-height
        }))
    ;; For simplicity, we'll assume the agency is verified
    ;; In production, you would use a proper contract-call to agency-verification
    (var-set next-service-id (+ service-id u1))
    (ok (map-set services service-id service-data))))

;; Update service details
(define-public (update-service
                (service-id uint)
                (name (string-utf8 100))
                (description (string-utf8 500)))
  (let ((service-data (unwrap! (map-get? services service-id) (err u404))))
    (if (is-eq tx-sender (get agency-principal service-data))
        (ok (map-set services
                     service-id
                     (merge service-data {
                       name: name,
                       description: description
                     })))
        (err u403))))

;; Deactivate a service
(define-public (deactivate-service (service-id uint))
  (let ((service-data (unwrap! (map-get? services service-id) (err u404))))
    (if (is-eq tx-sender (get agency-principal service-data))
        (ok (map-set services
                     service-id
                     (merge service-data {active: false})))
        (err u403))))

;; Reactivate a service
(define-public (reactivate-service (service-id uint))
  (let ((service-data (unwrap! (map-get? services service-id) (err u404))))
    (if (is-eq tx-sender (get agency-principal service-data))
        (ok (map-set services
                     service-id
                     (merge service-data {active: true})))
        (err u403))))

;; Get service details
(define-read-only (get-service-details (service-id uint))
  (map-get? services service-id))

;; Get current service count
(define-read-only (get-service-count)
  (- (var-get next-service-id) u1))
