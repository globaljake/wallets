import CustomElements from "./CustomElements";

const load = _app => {
  return import(/* webpackChunkName: "icon-svg" */ "./Icon.svg").then(text => {
    CustomElements.define(
      "ui-icon-injector",
      HTMLElement =>
        class extends HTMLElement {
          connectedCallback() {
            const div = document.createElement("div");
            div.style.display = "none";
            div.innerHTML = text.default;
            this.appendChild(div);
          }
        }
    );
  });
};

const createSvgIcon = (iconName, iconTitle) => {
  const SVG_NAMESPACE = "http://www.w3.org/2000/svg";
  const XLINK_NAMESPACE = "http://www.w3.org/1999/xlink";

  const svg = document.createElementNS(SVG_NAMESPACE, "svg");
  svg.setAttributeNS(null, "class", "w-full h-full block fill-current");
  const use = document.createElementNS(SVG_NAMESPACE, "use");
  use.setAttributeNS(XLINK_NAMESPACE, "xlink:href", `#icon-${iconName}`);

  if (iconTitle) {
    const titleNode = document.createElementNS(SVG_NAMESPACE, "title");
    const textNode = document.createTextNode(iconTitle);
    titleNode.appendChild(textNode);

    svg.setAttributeNS(null, "role", "img");
    svg.appendChild(titleNode);
  } else {
    svg.setAttributeNS(null, "aria-hidden", "true");
  }

  svg.appendChild(use);
  return svg;
};

const start = _app => {
  return load().then(() => {
    CustomElements.define(
      "ui-wallets-icon",
      HTMLElement =>
        class extends HTMLElement {
          constructor() {
            super();

            this._iconName = this.iconName || "";
            delete this.iconName;

            this._iconTitle = this.iconTitle || null;
            delete this.iconTitle;
          }

          set iconName(name) {
            if (this._iconName === name) return;
            this._iconName = name;
            while (this.firstChild) this.removeChild(this.firstChild);
            this._svgNode = createSvgIcon(this._iconName, this._iconTitle);
            this.appendChild(this._svgNode);
          }

          set iconTitle(title) {
            this._iconTitle = title;
          }

          connectedCallback() {
            this.className = "block w-full h-full";
            while (this.firstChild) this.removeChild(this.firstChild);
            this._svgNode = createSvgIcon(this._iconName, this._iconTitle);
            this.appendChild(this._svgNode);
          }
        }
    );
  });
};

export default {
  start
};
