import Vue from "vue";
import VueRouter from "vue-router";

import menuPage from "./components/menu.vue";
import gamePage from "./components/game.vue";

import indexPage from "./pages/index";
import creditsPage from "./pages/credits";
import howtoplayPage from "./pages/howtoplay";
import settingsPage from "./pages/settings";
import registerPage from "./pages/register";
import termsandconditionsPage from "./pages/termsandconditions";

Vue.use(VueRouter);

const router = new VueRouter({
  routes: [
    { path: "/", component: indexPage },
    { path: "/credits", component: creditsPage },
    { path: "/register", component: registerPage },
    { path: "/menu", component: menuPage },
    { path: "/game", component: gamePage },
    { path: "/howtoplay", component: howtoplayPage },
    { path: "/settings", component: settingsPage },
    { path: "/terms", component: termsandconditionsPage }
  ]
});

new Vue({router}).$mount("#application");
