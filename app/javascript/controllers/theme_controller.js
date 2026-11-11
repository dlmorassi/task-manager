import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "label"]

  connect() {
    this.currentTheme = localStorage.getItem("task-manager-theme") || "dark"
    this.applyTheme()
  }

  toggle() {
    this.currentTheme = this.currentTheme === "dark" ? "light" : "dark"
    localStorage.setItem("task-manager-theme", this.currentTheme)
    this.applyTheme()
  }

  applyTheme() {
    document.documentElement.dataset.theme = this.currentTheme
    const nextTheme = this.currentTheme === "dark" ? "light" : "dark"
    this.labelTarget.textContent = `${nextTheme === "dark" ? "Dark" : "Light"} mode`
    this.buttonTarget.setAttribute("aria-label", `Switch to ${nextTheme} mode`)
    this.buttonTarget.setAttribute("aria-pressed", this.currentTheme === "dark")
  }
}