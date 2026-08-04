import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "button", "showIcon", "hideIcon"]

  toggle() {
    const showingPassword = this.inputTarget.type === "text"

    this.inputTarget.type = showingPassword ? "password" : "text"
    this.buttonTarget.setAttribute(
      "aria-label",
      showingPassword ? "Show password" : "Hide password"
    )
    this.buttonTarget.setAttribute(
      "aria-pressed",
      showingPassword ? "false" : "true"
    )

    this.showIconTarget.classList.toggle("hidden", !showingPassword)
    this.hideIconTarget.classList.toggle("hidden", showingPassword)
  }
}