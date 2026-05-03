import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["typeSelect", "bodySection", "bodyInput", "assetSection", "assetUploader", "assetInput", "assetHint"];
  static values = { assetConfigs: Object, textType: String };

  connect() {
    this.sync();
  }

  sync() {
    const lessonType = this.typeSelectTarget.value;
    const textSelected = lessonType === this.textTypeValue;

    this.bodySectionTarget.classList.toggle("hidden", !textSelected);
    this.bodyInputTarget.disabled = !textSelected;

    this.assetSectionTarget.classList.toggle("hidden", textSelected);
    this.assetInputTarget.disabled = textSelected;

    if (textSelected) {
      return;
    }

    const assetConfig = this.assetConfigsValue[lessonType];
    if (!assetConfig) {
      return;
    }

    this.assetInputTarget.accept = assetConfig.accept;
    this.assetUploaderTarget.dataset.assetUploaderTypeValue = assetConfig.previewType;

    if (this.hasAssetHintTarget) {
      this.assetHintTarget.textContent = assetConfig.hint;
    }
  }
}
