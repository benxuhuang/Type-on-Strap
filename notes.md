#### Create a post

To create a `.md` file in the *_posts/* section with the jekyll format of today's date.
Use this command with the title you'd like to create the very basic post.

```bash
gulp post -n 'title of the post'
```

#### Minimizing and optimizing: css, js and images

You can run the default task that will compress the js, css and images and create the thumbnails for the supported image
formats:

```bash
cd assets/
gulp thumbnails-post
git status
```