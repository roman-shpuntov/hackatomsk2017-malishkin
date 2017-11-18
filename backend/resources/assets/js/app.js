import Vue from "vue";
import VueRouter from "vue-router";

import authorizePage from "./components/authorize.vue";
import registerPage from "./components/register.vue";

Vue.use(VueRouter);

const router = new VueRouter({
  routes: [
    { path: "/", component: authorizePage },
    { path: "/register", component: registerPage }
  ]
});

new Vue({router}).$mount("#application");
