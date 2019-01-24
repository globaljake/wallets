import { Elm } from "./Main.elm";
import "./Main.css";
import UiIcon from "./Ui/Icon";

const app = Elm.Main.init({});
UiIcon.start(app);
