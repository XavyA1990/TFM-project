import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["select", "button"];
  static values = {
    assignedRoleIds: Array,
    addLabel: String,
    removeLabel: String,
  };

  connect() {
    this.update();
  }

  update() {
    const selectedRoleId = Number(this.selectTarget.value);
    const assignedRoleIds = this.assignedRoleIdsValue.map((value) => Number(value));
    const hasRole = assignedRoleIds.includes(selectedRoleId);

    this.buttonTarget.textContent = hasRole ? this.removeLabelValue : this.addLabelValue;
    this.buttonTarget.className = hasRole
      ? this.buttonTarget.dataset.dangerClass
      : this.buttonTarget.dataset.defaultClass;
  }
}
