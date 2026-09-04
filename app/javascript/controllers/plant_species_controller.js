import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "species", "custom", "customInput", "photo", "identifyButton", "status"]
  static values = { identifyUrl: String }

  connect() {
    this.syncSpecies()
  }

  syncSpecies() {
    const customSelected = this.selectTarget.value === "__other__"
    this.customTarget.hidden = !customSelected
    this.speciesTarget.value = customSelected ? this.customInputTarget.value : this.selectTarget.value
  }

  async identify() {
    const photo = this.photoTarget.files[0]
    if (!photo) {
      this.showStatus("Choose a plant photo first.", true)
      return
    }

    this.identifyButtonTarget.disabled = true
    this.showStatus("Identifying plant…")

    try {
      const formData = new FormData()
      formData.append("photo", photo)
      const response = await fetch(this.identifyUrlValue, {
        method: "POST",
        headers: { "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content },
        body: formData
      })
      const result = await response.json()
      if (!response.ok) throw new Error(result.error || "Plant identification failed.")

      this.applyIdentification(result.species)
      this.showStatus(`Identified as ${result.species}. Please check this looks correct.`)
    } catch (error) {
      this.showStatus(error.message, true)
    } finally {
      this.identifyButtonTarget.disabled = false
    }
  }

  applyIdentification(species) {
    const latinName = species.split(" - ")[0].trim().toLowerCase()
    const matchingOption = Array.from(this.selectTarget.options)
      .find((option) => option.value.toLowerCase() === latinName)

    if (matchingOption) {
      this.selectTarget.value = matchingOption.value
    } else {
      this.selectTarget.value = "__other__"
      this.customInputTarget.value = species
    }
    this.syncSpecies()
  }

  showStatus(message, error = false) {
    this.statusTarget.textContent = message
    this.statusTarget.classList.toggle("text-danger", error)
  }
}
