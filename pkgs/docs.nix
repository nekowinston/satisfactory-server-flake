{
  lib,
  nixosOptionsDoc,
  modules ? [ ],
  version ? "unstable",
}:
let
  eval = lib.evalModules {
    modules = modules ++ [
      { config._module.check = false; }
    ];
  };

  doc = nixosOptionsDoc {
    options = lib.filterAttrs (
      n:
      lib.const (
        !(lib.elem n [
          "_module"
          "system"
        ])
      )
    ) eval.options;
    documentType = "none";
    revision = version;
  };
in
doc.optionsCommonMark
