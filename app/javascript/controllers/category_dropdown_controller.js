import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="category-dropdown"
export default class extends Controller {
  static targets = ["button", "options", "input", "buttonText"]

  connect() {
    this.isIndexPage = this.element.dataset.indexPage === "true"
    // Close the dropdown when clicking outside
    document.addEventListener('click', this.closeOutside.bind(this))
  }

  disconnect() {
    document.removeEventListener('click', this.closeOutside.bind(this))
  }

  toggle() {
    this.optionsTarget.classList.toggle('hidden')
  }

  select(event) {
    const selectedCategory = event.target.textContent
    this.buttonTarget.textContent = selectedCategory
    this.inputTarget.value = selectedCategory
    this.optionsTarget.classList.add('hidden')

    if (this.isIndexPage) {
      this.element.closest("form").requestSubmit()
    }
  }

  closeOutside(event) {
    if (!this.element.contains(event.target)) {
      this.optionsTarget.classList.add('hidden')
    }
  }
}
