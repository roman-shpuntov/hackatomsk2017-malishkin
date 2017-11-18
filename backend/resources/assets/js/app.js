import Vue from "vue";
import VueRouter from "vue-router";

import authorizePage from "./components/authorize.vue";
import registerPage from "./components/register.vue";
import menuPage from "./components/menu.vue";
import gamePage from "./components/game.vue";
import authorizedPage from "./components/authorized.vue";

import indexPage from "./pages/index";

Vue.use(VueRouter);

const router = new VueRouter({
  routes: [
    { path: "/", component: indexPage },
    { path: "/register", component: registerPage },
    { path: "/menu", component: menuPage },
    { path: "/game", component: gamePage },
    { path: "/authorized", component: authorizedPage }
  ]
});

new Vue({router}).$mount("#application");
