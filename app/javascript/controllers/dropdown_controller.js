import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["menu"];

  connect() {
    this.handleClickOutside = this.clickOutside.bind(this);
    this.handleEscape = this.escape.bind(this);

    document.addEventListener("click", this.handleClickOutside);
    document.addEventListener("keydown", this.handleEscape);
  }

  disconnect() {
    document.removeEventListener("click", this.handleClickOutside);
    document.removeEventListener("keydown", this.handleEscape);
  }

  toggle(event) {
    event.stopPropagation();
    this.menuTarget.classList.toggle("hidden");
  }

  close() {
    this.menuTarget.classList.add("hidden");
  }

  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close();
    }
  }

  escape(event) {
    if (event.key === "Escape") {
      this.close();
    }
  }
}
