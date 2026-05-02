import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["viewport"];

  previous() {
    this.scrollBy(-1);
  }

  next() {
    this.scrollBy(1);
  }

  scrollBy(direction) {
    const width = this.viewportTarget.clientWidth * 0.9;

    this.viewportTarget.scrollBy({
      left: width * direction,
      behavior: "smooth"
    });
  }
}
