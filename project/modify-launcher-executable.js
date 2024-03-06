/**
 * The sole purpose of this script is to modify the version information and icon of the Launcher project's built
 * executable. This is not a necessary step for the build process, but it is a nice-to-have for the final product.
 * It is required during the CI build process because .NET 6 will not compile this information into the executable
 * on a Linux environment. If the Launcher project is ever updated to .NET v8 this script will no longer be necessary.
 */
const fs = require('fs').promises;
const path = require('path');
const ResEdit = require('resedit-js');

const manifest = {
  icon: '/workspace/refringe/Build/build/project/icon.launcher.ico',
  author: 'SPT-AKI Launcher',
  description: 'The single-player modding framework for Escape From Tarkov.',
  name: 'aki-launcher',
  license: 'NCSA',
  version: '1.0.0', // TODO:
};

const serverExe = '/workspace/refringe/Build/assembled/Aki.Launcher.exe';

const updateBuildProperties = async () => {
    const exe = ResEdit.NtExecutable.from(await fs.readFile(serverExe));
    const res = ResEdit.NtExecutableResource.from(exe);

    const iconPath = path.resolve(manifest.icon);
    const iconFile = ResEdit.Data.IconFile.from(await fs.readFile(iconPath));

    ResEdit.Resource.IconGroupEntry.replaceIconsForResource(
        res.entries,
        1,
        1033,
        iconFile.icons.map((item) => item.data),
    );

    const vi = ResEdit.Resource.VersionInfo.fromEntries(res.entries)[0];

    vi.setStringValues({ lang: 1033, codepage: 1200 }, {
        ProductName: manifest.author,
        FileDescription: manifest.description,
        CompanyName: manifest.name,
        LegalCopyright: manifest.license,
    });
    vi.removeStringValue({ lang: 1033, codepage: 1200 }, "OriginalFilename");
    vi.removeStringValue({ lang: 1033, codepage: 1200 }, "InternalName");
    vi.setFileVersion(...manifest.version.split(".").map(Number));
    vi.setProductVersion(...manifest.version.split(".").map(Number));
    vi.outputToResourceEntries(res.entries);
    res.outputResource(exe, true);
    await fs.writeFile(serverExe, Buffer.from(exe.generate()));
};

updateBuildProperties().catch(console.error);
