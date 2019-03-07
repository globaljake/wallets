import { Elm } from "./Main.elm";
import "./Main.css";
import "./Ui/Transition.css";
import "./Ui/Modal.css";
import UiTransition from "./Ui/Transition";
import UiIcon from "./Ui/Icon";

const app = Elm.Main.init({});

UiTransition.start(app);
UiIcon.start(app);
