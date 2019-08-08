const _save = wallets => {
  localStorage.setItem("wallets", JSON.stringify(wallets));
};

const _get = () => JSON.parse(localStorage.getItem("wallets")) || {};

const create = ({ title, emoji, budget, available }) => {
  if (!title || !emoji || !budget || !available)
    return Promise.reject("Request payload insufficient");
  const wallets = _get();

  const id = Date.now() + "_wallet";
  const newWallet = { id, title, emoji, budget, available };

  _save({ [id]: newWallet, ...wallets });
  return Promise.resolve({ wallet: newWallet });
};

const index = () => {
  const wallets = _get();

  return Promise.resolve({
    feed: Object.keys(wallets).sort(),
    wallets: wallets
  });
};

const show = ({ id }) => {
  if (!id) return Promise.reject("Request payload insufficient");
  const wallets = _get();
  if (!wallets[id]) return Promise.reject("Item not found");

  return Promise.resolve({ wallet: wallets[id] });
};

const update = ({ id, title, emoji, budget }) => {
  if (!id) return Promise.reject("Request payload insufficient");
  const wallets = _get();
  if (!wallets[id]) return Promise.reject("Item not found");
  if (title) wallets[id].title = title;
  if (emoji) wallets[id].emoji = emoji;
  if (budget) wallets[id].budget = budget;
  _save(wallets);

  return Promise.resolve({ wallet: wallets[id] });
};

const delete_ = ({ id }) => {
  if (!id) return Promise.reject("Request payload insufficient");
  const wallets = _get();
  if (!wallets[id]) return Promise.reject("Item not found");
  delete wallets[id];
  _save(wallets);

  return Promise.resolve({ id });
};

export default { create, index, show, update, delete_ };
