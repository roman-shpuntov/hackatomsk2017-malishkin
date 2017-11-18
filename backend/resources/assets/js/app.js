import Vue from "vue";
import VueRouter from "vue-router";

import authorizePage from "./components/authorize.vue";

Vue.use(VueRouter);

const router = new VueRouter({
  routes: [
    { path: "/", component: authorizePage }
  ]
});

new Vue({router}).$mount("#application");
