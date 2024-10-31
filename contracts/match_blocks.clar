;; Dating App Smart Contract
;; This smart contract allows users to register and manage their dating profiles.
;; It includes functions to register a new profile, update an existing profile,
;; and retrieve profile details based on user addresses.

(define-map profiles
  {user: principal} ;; Key: User's principal
  { 
    name: (string-ascii 100),    ;; User's name
    age: uint,                   ;; User's age
    interests: (list 10 (string-ascii 50)), ;; List of user's interests, max 10 items
    location: (string-ascii 100) ;; User's location
  }
)

;; Custom assert function to handle errors
(define-private (assert! (condition bool) (err-msg (string-ascii 100)))
  (if condition
    (ok true)
    (err err-msg)
  )
)

;; Public function to register a new profile
(define-public (register-profile 
                  (name (string-ascii 100)) ;; User's name
                  (age uint)                ;; User's age
                  (interests (list 10 (string-ascii 50))) ;; User's interests, max 10 items
                  (location (string-ascii 100))) ;; User's location
  (begin
    ;; Ensure the profile does not already exist
    (match (assert! (is-none (map-get? profiles {user: tx-sender})) "Profile already exists")
      err err
      ok 
        (begin
          ;; Store the new profile in the profiles map
          (map-set profiles {user: tx-sender}
            { 
              name: name, 
              age: age, 
              interests: interests, 
              location: location 
            })
          (ok "Profile registered successfully.") ;; Return success message
        )
    )
  )
)

;; Public function to update an existing profile
(define-public (update-profile 
                  (name (string-ascii 100)) ;; User's name
                  (age uint)                ;; User's age
                  (interests (list 10 (string-ascii 50))) ;; User's interests, max 10 items
                  (location (string-ascii 100))) ;; User's location
  (begin
    ;; Ensure the profile exists before updating
    (match (assert! (is-some (map-get? profiles {user: tx-sender})) "Profile does not exist")
      err err
      ok
        (begin
          ;; Update the existing profile in the profiles map
          (map-set profiles {user: tx-sender}
            { 
              name: name, 
              age: age, 
              interests: interests, 
              location: location 
            })
          (ok "Profile updated successfully.") ;; Return success message
        )
    )
  )
)

;; Public function to retrieve a profile by user address
(define-public (get-profile (user principal))
  (let ((profile (map-get? profiles {user: user}))) ;; Retrieve the profile
    (ok (unwrap! profile (err "Profile not found"))) ;; Return profile data or error
  )
)

;; Public function to get all interests of the user as a list
(define-public (get-user-interests (user principal))
  (let ((profile (map-get? profiles {user: user}))) ;; Retrieve the profile
    (ok (get interests (unwrap! profile (err "Profile not found")))) ;; Return interests or error
  )
)
