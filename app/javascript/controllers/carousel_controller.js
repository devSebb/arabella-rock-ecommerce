import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="carousel"
export default class extends Controller {
  static targets = ["container"]

  connect() {
    this.currentIndex = 0
    this.totalSlides = this.containerTarget.children.length
    this.updateCarousel()
  }

  prev() {
    this.currentIndex = (this.currentIndex - 1 + this.totalSlides) % this.totalSlides
    this.updateCarousel()
  }

  next() {
    this.currentIndex = (this.currentIndex + 1) % this.totalSlides
    this.updateCarousel()
  }

  updateCarousel() {
    const offset = this.currentIndex * -100
    this.containerTarget.style.transform = `translateX(${offset}%)`
  }
}
