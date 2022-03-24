from dash import html
from dash import Dash, Input, Output
from fmu.sumo.explorer import Explorer  # type: ignore
from fmu.sumo.explorer import Case
from fmu.sumo.explorer._case_collection import CaseCollection  # type: ignore
from webviz_config import WebvizPluginABC
import webviz_core_components as wcc



class ListSurfacesPlugin(WebvizPluginABC):
    def __init__(
        self,
        app: Dash,
    ):
        super().__init__()
        self.set_callbacks(app)

    @property
    def layout(self) -> html.Div:
        return wcc.FlexBox([
            wcc.Frame(
                style={"flex": 1, "height": "90vh"},
                children=[
                    html.Button("Connect", id=self.uuid("connect_button")),
                ],
            ),
            wcc.Frame(
                style={"flex": 5},
                children=[
                    html.Div(
                        id=self.uuid("info_div"),
                    ),
                ],
            ),
        ])

    def set_callbacks(self, app: Dash) -> None:
        @app.callback(
            Output(self.uuid("info_div"), "children"),
            Input(self.uuid("connect_button"), "n_clicks"),
            prevent_initial_call=True,
        )
        def _connect_button_clicked(_n_clicks: int) -> list:
            print("CALLBACK _connect_button_clicked()")

            print("Connecting...")

            children = [html.U(html.B("Debug info:"))]

            try:
                sumo = Explorer(
                    env="dev",
                    logging_level="DEBUG",
                    write_back=True,
                )

                all_fields: dict = sumo.get_fields()
                print("\nall_fields:")
                print(all_fields)

                children.extend([
                    html.P("all_fields"),
                    html.P(str(all_fields)),
                ])

                selected_field = list(all_fields)[0]
                my_cases: CaseCollection = sumo.get_cases(fields=[selected_field])

                case_count = len(my_cases)
                outstr = f"\nmy_cases (count={case_count}, field={selected_field}):"
                print(outstr)
                children.append(html.P(outstr))
                for caseidx in range(case_count):
                    case: Case = my_cases[caseidx]
                    outstr = f"case {caseidx}: field={case.field_name}  case={case.case_name}"
                    print(outstr)
                    children.append(html.P(outstr))

                children.append(html.P("Connect done"))

            except Exception as exc:
                return [
                    html.U(html.B("Exception occurred:")),
                    html.P(str(exc)),
                ]

            return children
