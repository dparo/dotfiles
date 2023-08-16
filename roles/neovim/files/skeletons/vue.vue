<script setup lang="ts">
import { ref } from "vue";
const name = ref();
</script>

<template>
    <p class="greeting">Hello {{ name }}!</p>
</template>

<style>
.greeting {
    color: red;
    font-weight: bold;
}
</style>
