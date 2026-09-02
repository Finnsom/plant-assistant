import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="thinking"
export default class extends Controller {
  static targets = ["button"]

  call() {
    this.buttonTarget.disabled = true
    this.buttonTarget.value = "Thinking..."
  }
}
