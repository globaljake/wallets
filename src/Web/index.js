import { Elm } from "./Main.elm";
import "./Main.css";
import UiIcon from "../Wallets/Ui/Icon";
import UiPullToRefresh from "../Wallets/Ui/PullToRefresh";

const app = Elm.Web.Main.init({});

UiIcon.start(app);
UiPullToRefresh.start(app);
