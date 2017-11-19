<template>
  <form class="authorize-form" method="post" @submit="authorize">
    <input type="email" name="email" placeholder="Your Email">
    <input type="password" name="password" placeholder="Password">
    <input type="submit" value="Log in">
    <a class="register-link" href="#/register">Register</a>
  </form>
</template>

<script>
  export default {
    methods: {
      authorize(event) {
        fetch("/api/v1/login", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json"
          },
          body: JSON.stringify({
            email: event.target.email.value,
            password: event.target.password.value
          })
        }).then((request) => request.json()).then((data) => {
          localStorage.token = data.token;
          localStorage.name = data.name;
          this.$router.push("/");
        });

        event.preventDefault();
      }
    }
  }
</script>
