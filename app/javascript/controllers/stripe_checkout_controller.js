import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="stripe-checkout"
export default class extends Controller {
  static values = {
    publishableKey: String
  }

  connect() {
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
    .then(response => response.json())
    .then(data => {
      this.stripe.redirectToCheckout({ sessionId: data.id })
    })
    .catch((error) => {
      console.error('Error:', error)
    })
  }
}
