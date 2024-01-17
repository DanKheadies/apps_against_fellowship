enum PromptSpecial {
  draw2pick3,
  notSpecial,
  pick2,
}

PromptSpecial promptSpecial(String special) {
  if (special != '') {
    if (special.toUpperCase() == 'PICK 2') {
      return PromptSpecial.pick2;
    } else if (special.toUpperCase() == 'DRAW 2 PICK 3' ||
        special.toUpperCase() == 'DRAW 2, PICK 3') {
      return PromptSpecial.draw2pick3;
    }
  }
  return PromptSpecial.notSpecial;
}
