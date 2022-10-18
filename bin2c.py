import argparse


def bin2c(opts):
    with open(opts.in_file, "rb") as f:
        data = f.read()
        out_str = 'unsigned char ' + opts.name + '[]={'
        for i in data:
            out_str += hex(i) + ","
        out_str += "};"
        with open(opts.out, "w") as f_out:
            f_out.write(out_str)


if __name__ == '__main__':
    parse = argparse.ArgumentParser()
    parse.add_argument("in_file", help="input file")
    parse.add_argument("-o", "--out", required=True, help="out put file")
    parse.add_argument("-n", "--name", default="__FAT_BIN_DATA", help="var name")
    opt = parse.parse_args()
    bin2c(opt)
