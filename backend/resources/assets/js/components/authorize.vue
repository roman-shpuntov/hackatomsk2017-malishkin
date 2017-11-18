<template>
    <form method="post" @submit="authorize">
      <input type="email" name="email" placeholder="email">
      <input type="password" name="password" placeholder="password">
      <input type="submit" value="authorize">
      <a href="#/register">Register</a>
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
              console.log(data);
            });

            event.preventDefault();
          }
        }
    }
</script>
