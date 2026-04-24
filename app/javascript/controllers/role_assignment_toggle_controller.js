import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["select", "button"];
  static values = {
    assignedRoleTokens: Array,
    addLabel: String,
    removeLabel: String,
  };

  connect() {
    this.update();
  }

  update() {
    const selectedRoleToken = this.selectTarget.value;
    const hasRole = this.assignedRoleTokensValue.includes(selectedRoleToken);

    this.buttonTarget.textContent = hasRole ? this.removeLabelValue : this.addLabelValue;
    this.buttonTarget.className = hasRole
      ? this.buttonTarget.dataset.dangerClass
      : this.buttonTarget.dataset.defaultClass;
  }
}
