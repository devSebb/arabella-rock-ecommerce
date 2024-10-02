import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="stripe-checkout"
export default class extends Controller {
  static values = {
    publishableKey: String
  }

  connect() {
    if (!this.publishableKeyValue) {
      console.error("Stripe Publishable Key is not set")
      return
    }
    this.stripe = Stripe(this.publishableKeyValue)
  }

  checkout() {
    fetch('/orders', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
    })
    .then(response => {
      if (!response.ok) {
        return response.json().then(data => {
          throw new Error(data.error || `HTTP error! status: ${response.status}`)
        })
      }
      return response.json()
    })
    .then(data => {
      if (!data.id) {
        throw new Error('Session ID is missing in the response')
      }
      return this.stripe.redirectToCheckout({ sessionId: data.id })
    })
    .then(result => {
      if (result.error) {
        throw new Error(result.error.message)
      }
    })
    .catch((error) => {
      console.error('Error:', error)
      alert(`An error occurred during checkout: ${error.message}`)
    })
  }
}
