---
layout: post
title: Upgrade your vue project from Vue2 to Vue3
color: turquoise
feature-img: /assets/post-imgs/vuejs.jpg
thumbnail: /assets/post-imgs/vuejs.jpg
excerpt_separator: <!--more-->
tags:
  - vue2
  - vue3
---

## 1.Upgrade Vue CLI to the latest version

```shell
vue upgrade
```

{% include aligner.html images="image-20220608113243532.png" column=1 %}

<!--more-->

## 2.Modify **package.json** to install Vue 3, the migration build (@vue/compat), and the compiler for single file components (@vue/compiler-sfc)

## 2.Updating your `package.json` file
### install below packages
  - "vue": "^3.1.0-0"
  - "@vue/compat": "^3.1.0-0"
  - "@vue/compiler-sfc": "^3.1.0-0"
### remove below packages
  - "vue": "^2.6.11"
  -"vue-template-compiler": "^2.6.11"

```json
"dependencies": {
    "vue": "^3.1.0-0", // ADD
    "@vue/compat": "^3.1.0-0" // ADD
    "vue": "^2.6.11", // REMOVE
    ...
},
"devDependencies": {
    "@vue/compiler-sfc": "^3.1.0-0" // ADD
    "vue-template-compiler": "^2.6.11" // REMOVE
    ...
}
```
<!--more-->

```shell
npm install
```

## 3.Create a `vue.config.js` file to set up some compiler options:

```javascript
module.exports = {
  chainWebpack: config => {
    config.resolve.alias.set('vue', '@vue/compat')

    config.module
      .rule('vue')
      .use('vue-loader')
      .tap(options => {
        return {
          ...options,
          compilerOptions: {
            compatConfig: {
              MODE: 2
            }
          }
        }
      })
    }
}
```

## 4.And then to restart the development server:

```shell
  npm run serve
```

## 5.Fix errors

## 6.Upgrade Vuex and Vue-Router

```json
"vue-router": "^4.0.0",
"vuex": "^4.0.0"
```

### Update Vuex file

```javascript
import { createStore } from 'vuex'
import modules from './modules'
const store = createStore({ modules, strict: false })

export default store
```

### Update Vue-Router file

```javascript
import routes from './routes'
import { createRouter, createWebHashHistory } from 'vue-router'

const router = new createRouter({
    routes,
    history: createWebHashHistory(),
});

export default router
```

## 7.Replace bootstrap-vue with [bootstrap-vue-3](https://cdmoro.github.io/bootstrap-vue-3/getting-started/#why-bootstrapvue3), because bootstrap-vue is not yet ready for Vue3

```shell
npm install --save bootstrap bootstrap-vue-3 @popperjs/core
```

```javascript
import {createApp} from 'vue'
import BootstrapVue3 from 'bootstrap-vue-3'
import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap-vue-3/dist/bootstrap-vue-3.css'

const app = createApp(App)
app.use(BootstrapVue3)
app.mount('#app')
```

## 參考:

1. [bootstrap-vue-3](https://www.npmjs.com/package/bootstrap-vue-3)
2. [installation-vue-js](https://cdmoro.github.io/bootstrap-vue-3/getting-started/#installation-vue-js)
3. [how-to-use-vue-3-add-plugin-boostrap-vue](https://stackoverflow.com/questions/63570340/how-to-use-vue-3-add-plugin-boostrap-vue)

