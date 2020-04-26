import { Elm } from "./Main.elm";
import "./index.css";
import UiIcon from "../Wallets/Ui/Icon";

const app = Elm.Web.Main.init({});

UiIcon.start(app);
