import { Elm } from "./Main.elm";
import "./Main.css";
import UiIcon from "../Wallets/Ui/Icon";
import LocalRequest from "../Wallets/LocalRequest";

LocalRequest.init();

const app = Elm.Web.Main.init({});

UiIcon.start(app);
