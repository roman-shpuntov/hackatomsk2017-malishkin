import Vue from "vue";
import VueRouter from "vue-router";

import authorizePage from "./components/authorize.vue";
import registerPage from "./components/register.vue";
import menuPage from "./components/menu.vue";
import gamePage from "./components/game.vue";

Vue.use(VueRouter);

const router = new VueRouter({
  routes: [
    { path: "/", component: authorizePage },
    { path: "/register", component: registerPage },
    { path: "/menu", component: menuPage },
    { path: "/game", component: gamePage }
  ]
});

new Vue({router}).$mount("#application");
