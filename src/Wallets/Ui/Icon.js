import CustomElements from "./CustomElements";

const start = _app => {
  return import(/* webpackChunkName: "icon-svg" */ "./Icon.json").then(
    ({ default: paths }) => {
      CustomElements.define(
        "wallets-ui-icon",
        HTMLElement =>
          class extends HTMLElement {
            constructor() {
              super();

              this._name = this.name || "";
              delete this.name;
            }

            connectedCallback() {
              const SVG_NS = "http://www.w3.org/2000/svg";
              const svg = document.createElementNS(SVG_NS, "svg");
              svg.classList.add("w-full", "h-full", "block", "fill-current");
              const path = document.createElementNS(SVG_NS, "path");
              path.setAttribute("d", paths[this._name]);
              svg.appendChild(path);

              this.appendChild(svg);
            }
          }
      );
    }
  );
};

export default { start };
