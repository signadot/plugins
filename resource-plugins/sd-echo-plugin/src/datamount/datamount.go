package datamount

import (
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"
)

const limBytes = 1024 * 1024 // k8s secret size limit

func ReadDataMount(dir string) (map[string][]byte, error) {
	dir, err := filepath.EvalSymlinks(dir)
	if err != nil {
		return nil, err
	}
	entries, err := os.ReadDir(dir)
	if err != nil {
		return nil, err
	}
	var res = map[string][]byte{}
	for _, entry := range entries {
		if strings.HasPrefix(entry.Name(), ".") {
			continue
		}
		fileName := filepath.Join(inputDir, entry.Name())
		fileName, err := filepath.EvalSymlinks(fileName)
		if err != nil {
			return nil, err
		}
		st, err := os.Stat(fileName)
		if err != nil {
			return nil, fmt.Errorf("unable to stat %q: %s", fileName, err)
		}
		if st.IsDir() {
			if !strings.HasPrefix(st.Name(), ".") {
				log.Printf("skipping subdirectory %q, mount should not contain subdirectories")
			}
			continue
		}
		if st.Size() > limBytes {
			return nil, fmt.Errorf("file %q too big: %d > %d", st.Name(), st.Size(), limBytes)
		}
		d, e := os.ReadFile(fileName)
		if e != nil {
			return nil, e
		}
		res[entry.Name()] = d
	}
	return res, nil
}

func WriteDataMount(dir string, data map[string][]byte) error {
	ttl := 0
	for k, v := range data {
		ttl += len(k) + len(v)
	}
	if ttl > limBytes {
		return fmt.Errorf("total size %d too big (> %d)", ttl, limBytes)
	}
	for k, v := range data {
		p := filepath.Join(dir, k)
		err := func() error {
			f, e := os.Create(p)
			if e != nil {
				return e
			}
			defer f.Close()
			_, e = f.Write(v)
			return e
		}()
		if err != nil {
			return err
		}
	}
	return nil
}
