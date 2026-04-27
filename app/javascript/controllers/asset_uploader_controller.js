import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["dropzone", "input", "preview", "image", "video", "fileCard", "filename", "meta"];
  static values = { type: String };

  connect() {
    this.objectUrl = null;
  }

  disconnect() {
    this.releaseObjectUrl();
  }

  open() {
    this.inputTarget.click();
  }

  change() {
    this.updateFromInput();
  }

  dragEnter(event) {
    event.preventDefault();
    this.highlight();
  }

  dragOver(event) {
    event.preventDefault();
    this.highlight();
  }

  dragLeave(event) {
    event.preventDefault();

    if (this.dropzoneTarget.contains(event.relatedTarget)) {
      return;
    }

    this.unhighlight();
  }

  drop(event) {
    event.preventDefault();
    this.unhighlight();

    if (!event.dataTransfer?.files?.length) {
      return;
    }

    this.inputTarget.files = event.dataTransfer.files;
    this.updateFromInput();
  }

  updateFromInput() {
    const file = this.inputTarget.files[0];

    if (!file) {
      return;
    }

    this.filenameTarget.textContent = file.name;
    this.metaTarget.textContent = this.buildMeta(file);
    this.previewTarget.classList.remove("hidden");

    const kind = this.fileKind(file.type);
    this.setKind(kind);

    if (kind === "image" || kind === "video") {
      this.releaseObjectUrl();
      this.objectUrl = URL.createObjectURL(file);

      if (kind === "image") {
        this.imageTarget.src = this.objectUrl;
      } else {
        this.videoTarget.src = this.objectUrl;
      }
    } else {
      this.releaseObjectUrl();
    }
  }

  highlight() {
    this.dropzoneTarget.classList.add("border-indigo-500", "bg-indigo-50/60", "dark:bg-indigo-500/10");
  }

  unhighlight() {
    this.dropzoneTarget.classList.remove("border-indigo-500", "bg-indigo-50/60", "dark:bg-indigo-500/10");
  }

  setKind(kind) {
    this.imageTarget.classList.toggle("hidden", kind !== "image");
    this.videoTarget.classList.toggle("hidden", kind !== "video");
    this.fileCardTarget.classList.toggle("hidden", !["pdf", "file"].includes(kind));

    const badgeLabels = {
      pdf: "PDF",
      file: "FILE",
    };

    this.fileCardTarget.textContent = badgeLabels[kind] || "PREVIEW";
  }

  buildMeta(file) {
    return [file.type || null, this.formatBytes(file.size)].filter(Boolean).join(" · ");
  }

  fileKind(contentType) {
    if (!contentType) {
      return this.typeValue || "file";
    }

    if (contentType.startsWith("image/")) {
      return "image";
    }

    if (contentType.startsWith("video/")) {
      return "video";
    }

    if (contentType === "application/pdf") {
      return "pdf";
    }

    return "file";
  }

  formatBytes(bytes) {
    if (!bytes) {
      return "0 B";
    }

    const units = ["B", "KB", "MB", "GB"];
    const size = Math.floor(Math.log(bytes) / Math.log(1024));
    const value = bytes / (1024 ** size);

    return `${value.toFixed(value >= 10 || size === 0 ? 0 : 1)} ${units[size]}`;
  }

  releaseObjectUrl() {
    if (!this.objectUrl) {
      return;
    }

    URL.revokeObjectURL(this.objectUrl);
    this.objectUrl = null;
  }
}
