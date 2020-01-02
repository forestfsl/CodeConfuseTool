#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import random
import nltk

# nltk.download()
# 自然语言混淆方案

# 需要混淆的模版文件
# input_template_file = "K_full.h"   # K版本完整混淆
# input_template_file = "Confuse.h"
# input_template_file = "NSDKHeader.h"
# input_template_file = "Unity.h"
# input_template_file = "FLPSDK.h"
# input_template_file = "H22StoreHeader.h"
# input_template_file = "TecentHeader.h"
# input_template_file = "filename.h"
input_template_file = "/Users/songlin/CodeConfuseTool/CoderTools/script/input.h"
# input_template_file = "StoryHeader.h"
# input_template_file = "C.h"
# 混淆好的内容输出到文件
output_file = "/Users/songlin/CodeConfuseTool/CoderTools/script/output.h"

#前缀
class_prefix = ""
method_prefix = ""
#后缀
clsss_suffix = ""
method_suffix = ""

# 不替换的单词（介词）
ignore_list = ["in", "on", "at", "for", "with", "since", "from", "ago", "before", "after", "through", "during", "while",
               "until", "till", "like", "according", "because", "but", "upon", "except", "under", "between", "blong",
               "to", "of", "over", "by", "into", "as", "about", "and", "controller", "view", "cell", "label", "control",
               "JSON", "HTTP", "NS"]

input_fo = open(input_template_file, "r+")
output_fo = open(output_file, "w+")


# 将方法名分解为单词列表
def method_to_words(method_string):
    # 返回结果
    result = []
    # 单词索引
    word_index = 0
    # 单词开始位置
    word_start = 0
    # 单词结束位置
    word_end = 0
    # 字母大小写状态
    letter_status = False  # 小写
    # 全部是小写字母
    if method_string.islower():
        if method_string.find("_") > 0:
            item_list = method_string.split("_")
            for separate in item_list:
                if len(separate) > 0:
                    result.append(separate)
            return result
        else:
            return [method_string]

    # 全部是大写字母
    if method_string.isupper():
        if method_string.find("_") > 0:
            item_list = method_string.split("_")
            for separate in item_list:
                if len(separate) > 0:
                    result.append(separate)
            return result
        else:
            return [method_string]

    # 大小写混合下划线
    output_word_list = []
    for letter in method_string:

        word_index = word_index + 1
        word_end = word_end + 1

        if letter.isupper():
            # 第一个字母
            if word_end == 1:
                letter_status = True  # 大写
            else:
                if letter_status == False:
                    output_word_list.append(method_string[word_start:word_end - 1])
                    letter_status = True
                    word_start = word_end - 1

        if letter.islower():
            # 第一个字母
            if word_end == 1:
                letter_status = False  # 小写
            else:
                if letter_status == True:
                    # 新的单词（连续的大写字母接着是小写字母）
                    if (word_end - word_start > 2):
                        output_word_list.append(method_string[word_start:word_end - 2])
                        letter_status = False
                        word_start = word_end - 2
                    else:
                        letter_status = False

    output_word_list.append(method_string[word_start:word_end])

    for item in output_word_list:
        if item.find("_") > 0:
            item_list = item.split("_")
            for separate in item_list:
                if len(separate) > 0:
                    result.append(separate)
        else:
            result.append(item)

    return result


# 开始混淆
def confuse_all():
    # 当前方法名
    current_method_name = ""
    # 混淆后方法名
    confused_method_name = ""
    # 读取模版
    input_template_fo = open(input_template_file, "r+")

    for line in input_template_fo.readlines():
        line = line.strip()
        input_list = line.split(" ")
        if len(input_list) == 3:
            # 原始方法名
            original_method_name = input_list[1]
            if current_method_name != original_method_name:
                # 以下划线_开头
                if original_method_name.find("_") == 0:
                    if "_" + current_method_name == original_method_name:
                        output_fo.write(
                            input_list[0] + " " + original_method_name + " " + "_" + confused_method_name + "\n")
                    else:
                        current_method_name = original_method_name
                        confused_method_name = nature_language_confuse(original_method_name)
                        output_fo.write(
                            input_list[0] + " " + original_method_name + " " + confused_method_name + "\n")
                # 以set开头
                elif original_method_name.find("set") == 0:
                    if "set" + current_method_name[0:1].upper() + current_method_name[1:] == original_method_name:
                        output_fo.write(
                            input_list[0] + " " + original_method_name + " " + "set" + confused_method_name[0:1].upper()
                            + confused_method_name[1:] + "\n")
                    else:
                        current_method_name = original_method_name
                        confused_method_name = nature_language_confuse(original_method_name)
                        output_fo.write(
                            input_list[0] + " " + original_method_name + " " + confused_method_name + "\n")
                else:
                    current_method_name = original_method_name
                    confused_method_name = nature_language_confuse(original_method_name)
                    output_fo.write(
                        input_list[0] + " " + original_method_name + " " + confused_method_name + "\n")


# 自然语言混淆
def nature_language_confuse(method_string):
    word_list = method_to_words(method_string)
    index = 1
    result = ""

    for item in word_list:
        # 忽略单词不替换
        if item.lower() in ignore_list:
            result = result + item
            index = index + 1
            continue

        tokens = nltk.word_tokenize(item)
        pos_tags = nltk.pos_tag(tokens)

        for word, pos in pos_tags:
            nature_laguage_word_list = open('/Users/songlin/CodeConfuseTool/CoderTools/script/nature/' + pos + '.txt', 'r').readlines()
            if item[0:1].isupper():
                result = result + nature_laguage_word_list[random.randint(0, len(nature_laguage_word_list) - 1)].strip().capitalize()
            else:
                result = result + nature_laguage_word_list[random.randint(0, len(nature_laguage_word_list) - 1)].strip().lower()

        index = index + 1
    if result[0:1].isupper():
        result = class_prefix + result + clsss_suffix
    else:
        result = method_prefix + result + method_suffix
    return result


# 执行混淆方法
confuse_all()
# 测试
# print(method_to_words('BYAFPropertyListRequestSerializer'))
# print(method_to_words('isMutableTaskDelegatesKeyedByTaskIdentifier'))
# print(nature_language_confuse('coral_purchaseProductWithParams'))
