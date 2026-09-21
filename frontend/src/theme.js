import { createTheme } from "@mui/material/styles";

const theme = createTheme({
  palette: {
    primary: {
      main: "#1565C0",
    },
    secondary: {
      main: "#2E7D32",
    },
    background: {
      default: "#0F2E4C",
    },
  },

  typography: {
    fontFamily: "Roboto, Arial, sans-serif",
  },

  shape: {
    borderRadius: 8,
  },
});

export default theme;