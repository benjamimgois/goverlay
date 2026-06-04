#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
    char *infile = argv[1];
    char *outfile = argv[2];

    FILE *fp = fopen(infile, "rb");
    fseek(fp, 0, SEEK_END);
    size_t size = ftell(fp);
    fseek(fp, 0, SEEK_SET);

    uint8_t *data = (uint8_t *)malloc(size);
    fread(data, 1, size, fp);
    fclose(fp);

    char *header_filename = (char *)malloc(strlen(outfile) + 3);
    sprintf(header_filename, "%s.h", outfile);
    char *source_filename = (char *)malloc(strlen(outfile) + 3);
    sprintf(source_filename, "%s.c", outfile);

    FILE *header_file = fopen(header_filename, "w");
    FILE *source_file = fopen(source_filename, "w");

    fprintf(header_file, "#ifndef %s_H_\n", outfile);
    fprintf(header_file, "#define %s_H_\n", outfile);
    fprintf(header_file, "\n#include <stdint.h>\n");
    fprintf(header_file, "\n#define DOOM_SIZE %zu\n", size);
    fprintf(header_file, "#define DOOM_FILENAME \"%s\"\n", infile);
    fprintf(header_file, "\nextern const uint8_t* doom;\n");
    fprintf(header_file, "\n#endif\n");
    fclose(header_file);

    fprintf(source_file, "#include \"%s\"\n\n", header_filename);
    fprintf(source_file, "static const uint8_t doom_data[] = {\n");

    for (int i = 0; i < size; i++)
    {
        fprintf(source_file, "0x%02X,", data[i]);
        if ((i + 1) % 16 == 0)
        {
            fprintf(source_file, "\n");
        }
    }

    fprintf(source_file, "};\n\nconst uint8_t* doom = doom_data;\n");
    fclose(source_file);

    free(data);
    free(header_filename);
    free(source_filename);

    return 0;
}
