### runvqgan: Functions for running VQGAN-CLIP on my workstation

# Readme file for running VQGAN-CLIP on Alex's workstation

*Last updated 06 February 2022*


## Task files

- Task files are text files with the file extension `.txt` in the `tasks` folder, or a file of the form `"task_ ... .txt"` in your personal folder.
- Task file names should not contain spaces or special character such as German *umlaute*.
- Files named `"sample.txt"` or `"task_sample.txt"` will not be processed; they serve as templates for creating your own task files; please don't overwrite the existing sample task files :-)
- The contents of the task files are described below.

## Processing

- All task files will be read daily at 11pm and used to run the tasks on my workstation; they may sometimes also be processed during the day
- a single image takes between 1 and 3 minutes with typical settings (up to 500 iterations), but of course it will take substantially longer with more iterations
- My script may limit the number of iterations (up to 6000 or so) and repetitions per task (currently no more than 25)
- Processed task files are renamed -> `".done"` is added as an additional file extension, but it's still the same text file so you can rename and re-use it...
- If there's an error, a file with `"ERROR"` in its name will be created...

## More information

For more information on the underlying model see here (scroll to the bottom): <https://github.com/nerdyrodent/VQGAN-CLIP>

## Structure of task files

Task files are text files in JSON format. They contain a single list (surrounded by curly braces, `{...}`) with the following fields:

### Text

>   "text": ["A painting of a something doing something"],

A text describing what you want the AI system to paint. As far as I know this should normally start with `"A painting of"` or `"A picture of"` (`"picture"` may look at bit more photo-like). But you can also just write anything...

The text must not contain quotation marks!

English and German language texts both work; I haven't tried other languages. There may be "spillover" effects between the languages; e.g. a painting of Justin Bieber on stage (which was requested in English) showed a crossover of Justing Bieber and a beaver (=Bieber in German).

You can optionally also add a style, but this will only work if the following `"style"` attribute is `""`: E.g. you could write `"A painting of a dog|surreal:0.25|weird:0.1|psychedelic:0.25"` - you get the idea, but I don't know which other styles are supported...

### Style

>  `"style": ["", "Banksy"],`

Image styles (one or multiple), e.g. `""` for default style (nothing special), `"Banksy"` for Banksy, `"Picasso"` for Picasso, `"surrealism"`, `"impressionism"` etc. - I don't know if a list of supported styles exists of if this could be any style and it will try to infer the style from its knowledge base (`"in the style of Brenning"` haha...). Let me know if you find out which styles are supported...

Note that `"style"` is the ONLY field that accepts multiple inputs; to iterate over different texts etc., you will have to create multiple task files.

### Number of iterations

>  `"iterations": [200],`

Number of iterations. Should be at least 80 or so. With a few hundred iterations, the image should already be consistent with the chosen style. I'm not sure if it'll improve a lot with more than 1000 iterations.

### Output file name

>  `"out_file": ["something"],`

Output file name; files will be named, for example, `"something_1.png"`, `"something_2.png"`, with numbers in increasing order. I recommend using a unique name, such as `"John_robot"` if you're John and you want to create a series of images involving robots. Existing files will NOT be overwritten. With each output file, there will be one `.txt` file that contains the actual VQGAN-CLIP call that was used to create the image. This can be useful to remember how the image was actually created...

### Output folder

>  `"out_folder": ["output"],`

Output folder that I shared with you, "output" by default, which is a folder to which all of us have access. If a "private" VQGAN folder was assigned to you, better use that folder instead.

### Portrait or landscape format

>  `"portrait": [false],`

Image in landscape mode (false) or portrait mode (true). (Resolution is 450 x 300 pixels and 300 x 450 pixels, respectively.)

### Number of repetitions

>  `"each": [1]`

Number of times the task should be repeated. For example, with `"each"` equal to 5, and two `"style"`s chosen above, 5 $\times$ 2 = 10 images will be created in total.

### Resolution (optional)

>  `"resolution": [450, 300]`

Image size (number of pixels) in x and y direction. Must not be greater than $450\times 300$. Note that `"portrait"` will *always* define whether the image is in portrait or landscape mode, i.e. the order of the values in `"resolution"` will be overridden. 

## Background reading

- Katherine Crowson's Github repo for running VQGAN+CLIP locally: <https://github.com/nerdyrodent/VQGAN-CLIP>

- L.J. Miranda: The Illustrated VQGAN <https://ljvmiranda921.github.io/notebook/2021/08/08/clip-vqgan/>

