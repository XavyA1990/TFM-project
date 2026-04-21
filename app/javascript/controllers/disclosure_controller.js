import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["panel", "button", "openIcon", "closeIcon"];

  connect() {
    this.open = false;
    this.render();
  }

  toggle() {
    this.open = !this.open;
    this.render();
  }

  render() {
    this.panelTarget.classList.toggle("hidden", !this.open);
    this.openIconTarget.classList.toggle("hidden", this.open);
    this.closeIconTarget.classList.toggle("hidden", !this.open);
    this.buttonTarget.setAttribute("aria-expanded", String(this.open));
  }
}
