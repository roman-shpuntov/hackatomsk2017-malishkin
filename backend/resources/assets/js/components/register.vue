<template>
  <form class="register-form" method="post" @submit="authorize">
    <input type="email" name="email" placeholder="Your Email">
    <input type="text" name="username" placeholder="Your name">
    <input type="password" name="password" placeholder="Your password">
    <input type="submit" value="register">
  </form>
</template>

<script>
  export default {
    methods: {
      authorize(event) {
        fetch("/api/v1/user", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json"
          },
          body: JSON.stringify({
            name: event.target.username.value,
            email: event.target.email.value,
            password: event.target.password.value
          })
        }).then((request) => request.json()).then((data) => {
          localStorage.token = data.token;
          localStorage.user_id = data.user_id;
          localStorage.user_name = data.name;
          this.$router.push("/");
        });

        event.preventDefault();
      }
    }
  }
</script>
