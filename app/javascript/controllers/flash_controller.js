import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    delay: { type: Number, default: 1000 },
  };

  connect() {
    this.timeout = setTimeout(() => {
      this.element.remove();
    }, this.delayValue);
  }

  disconnect() {
    clearTimeout(this.timeout);
  }

  hide() {
    setTimeout(() => {
      this.element.remove();
    }, 500);
  }

  close() {
    clearTimeout(this.timeout);
    this.hide();
  }
}
